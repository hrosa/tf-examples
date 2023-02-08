package accounting_service_test

import (
	"context"
	"fmt"
	"io"
	"log"
	"os"
	"testing"
	"time"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/client"
	"github.com/docker/docker/pkg/jsonmessage"
	"github.com/docker/go-connections/nat"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/moby/term"
)

func TestEntrypoint(t *testing.T) {
	//t.Run("TestDataProducer", RunDataProducerTestsuite)
	t.Run("TestApiPurchases", RunApiPurchasesTestsuite)
	//t.Run("TestApiPurchases", RunApiRepairsTestsuite)
}

func RunTestGroup(t *testing.T, tfModule string, subTests []func(t *testing.T)) {
	// GIVEN
	var localStackImage = "localstack/localstack:1.3.0"
	cli, err := client.NewClientWithOpts(client.FromEnv)
	if err != nil {
		panic(err)
	}

	pwd, _ := os.Getwd()
	localstackDir := pwd + "/target/localstack-data"
	localstackDirState := localstackDir + "/state"

	os.Mkdir(localstackDir, 0777)
	os.Mkdir(localstackDirState, 0777)

	//Remove State directory where state is kept
	defer os.RemoveAll(localstackDirState)

	t.Logf("Will use temporary directory [%v] for LocalStack", localstackDir)

	var localStackContainer = LaunchLocalStack(cli, localStackImage, localstackDir)
	defer CleanupLocalStack(cli, localStackContainer)

	// WHEN
	terraformOptions := &terraform.Options{
		TerraformDir:       tfModule,
		Lock:               false,
		Upgrade:            true,
		MaxRetries:         1,
		MigrateState:       true,
		TimeBetweenRetries: 5 * time.Second,
		EnvVars: map[string]string{
			"TF_LOG": "INFO",
		},
	}

	defer CleanupTerraform(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Run test groups, one at a time
	for i, tc := range subTests {
		t.Run(fmt.Sprint("subtest", i), tc)
	}
}

func LaunchLocalStack(cli *client.Client, imageName string, tempDir string) string {
	pull, err := cli.ImagePull(context.Background(), imageName, types.ImagePullOptions{})
	if err != nil {
		println("Failed to pull image: ", err)
		panic(err)
	}
	var writeBuff io.Writer = os.Stderr
	outFd, isTerminalOut := term.GetFdInfo(os.Stderr)

	_ = jsonmessage.DisplayJSONMessagesStream(pull, writeBuff, outFd, isTerminalOut, nil)
	if err = pull.Close(); err != nil {
		panic(err)
	}

	portRange, _ := nat.NewPort("tcp", "4510-4559")
	portBindings := nat.PortMap{}

	for _, rawMapping := range []string{
		"0.0.0.0:4510-4559:4510-4559",
		"0.0.0.0:4566:4566",
	} {
		mappings, err := nat.ParsePortSpec(rawMapping)
		if err != nil {
			panic(err)
		}
		for _, pm := range mappings {
			portBindings[pm.Port] = []nat.PortBinding{pm.Binding}
		}
	}

	resp, err := cli.ContainerCreate(
		context.Background(),
		&container.Config{
			Image: imageName,
			ExposedPorts: nat.PortSet{"4566": struct{}{},
				portRange: struct{}{}},
			Env: []string{
				//"LOCALSTACK_API_KEY=xxxxxxxxxx",
				// Per default, all services are loaded and started on the first request for that service.
				"AWS_DEFAULT_REGION=us-east-1",
				"AWS_SECRET_ACCESS_KEY=secretkey",
				"AWS_ACCESS_KEY_ID=accesskey",
				"DOCKER_HOST=unix:///var/run/docker.sock",
				"DEFAULT_REGION=us-east-1",
				"DOCKER_BRIDGE_IP=172.17.0.1",
				"DEBUG=0",
				"LS_LOG=debug", //trace, trace-internal, debug, info, warn, error, warning
				"DATA_DIR=/tmp/localstack/data",
				"PERSISTENCE=1",
				"PERSIST_ALL=true",
				"ENFORCE_IAM=1",
				"IAM_SOFT_MODE=0",
				// ELASTIC SEARCH
				"OPENSEARCH_ENDPOINT_STRATEGY=domain",
				// LAMBDA
				"LAMBDA_EXECUTOR=local",
			},
		},
		&container.HostConfig{
			PortBindings: portBindings,
			Binds: []string{
				"/var/run/docker.sock:/var/run/docker.sock",
				tempDir + ":/var/lib/localstack",
			},
			Privileged: true,
		},
		nil, nil, "accounting-service-test")
	if err != nil {
		log.Println("Failed to create LocalStack container: ", err)
		panic(err)
	}

	if err := cli.ContainerStart(context.Background(), resp.ID, types.ContainerStartOptions{}); err != nil {
		log.Println("Failed to start LocalStack container: ", err)
		panic(err)
	}
	log.Println("LocalStack container started successfully!")

	return resp.ID
}

func CleanupLocalStack(cli *client.Client, containerName string) {
	var timeout = 10 * time.Second

	if err := cli.ContainerStop(context.Background(), containerName, &timeout); err != nil {
		log.Printf("Unable to stop container %s: %s", containerName, err)
	}

	if err := cli.ContainerRemove(context.Background(), containerName, types.ContainerRemoveOptions{
		Force: true,
	}); err != nil {
		log.Printf("Unable to remove container: %s", err)
	}
}

func CleanupTerraform(t *testing.T, options *terraform.Options) {
	if _, err := terraform.DestroyE(t, options); err != nil {
		log.Printf("Failed to destroy terraform resources: %s", err)
	}
}
