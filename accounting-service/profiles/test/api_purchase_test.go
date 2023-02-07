package accounting_service_test

import (
	"bytes"
	"io"
	"net/http"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func RunApiPurchasesTestsuite(t *testing.T) {
	RunTestGroup(t, "./test_api_purchase", []func(t *testing.T){readDataScenario})
}

func readDataScenario(t *testing.T) {
	client := &http.Client{}

	url := "http://purchase.us-east-1.es.localhost.localstack.cloud:4566/purchases/_doc"
	payload := []byte(`{"id": "12345", date_created: "01-01-2023 12:00:00", "description": "Laptop xyz", "value": 600, "currency": "EUR"}`)
	bodyReader := bytes.NewReader(payload)
	req, err := http.NewRequest(http.MethodPost, url, bodyReader)
	if err != nil {
		t.Errorf("Exception to create Req %v", err)
	}
	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("Accept", "application/json")
	res, _ := client.Do(req)
	body, err := io.ReadAll(res.Body)
	if err != nil {
		t.Errorf("Exception to get Resp %v", err)
		return
	}
	t.Logf("ES Doc Put %v", string(body))

	terraformOptions := &terraform.Options{
		TerraformDir:       "./sdr_api",
		Lock:               false,
		Upgrade:            true,
		MaxRetries:         1,
		MigrateState:       true,
		TimeBetweenRetries: 5 * time.Second,
	}

	outputAll := terraform.OutputAll(t, terraformOptions)

	t.Logf("Terraform output %v", outputAll)

	apiId := outputAll["sdr_api_id"].(string)
	stageId := outputAll["sdr_api_gateway_stage_name"].(string)

	//The request to APIGW will result in empty response because of a VLT bug at localstack  https://github.com/localstack/localstack/issues/7188
	url = "http://" + apiId + ".execute-api.localhost.localstack.cloud:4566/" + stageId + "/api/2012-04-24/Accounts/AC40ea78485341fe8a47763043506064b5/Recordings"
	req, err = http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		t.Errorf("Exception to create Req %v", err)
	}
	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("Accept", "application/json")
	req.Header.Add("Authorization", "Basic 1234567890")
	t.Logf("About to issue Account Req to %v", url)

	res, _ = client.Do(req)
	body, err = io.ReadAll(res.Body)
	if err != nil {
		t.Errorf("Exception to get Resp %v", err)
		return
	}
	t.Logf("Recording API Search %v", string(body))
}
