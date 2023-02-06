package accounting_service_test

import (
	"flag"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/credentials/stscreds"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kinesis"
	"gotest.tools/v3/assert"
)

func RunDataProducerTestsuite(t *testing.T) {
	RunTestGroup(t, "./test_producer", []func(t *testing.T){writeData})
}

func writeData(t *testing.T) {
	// GIVEN
	creds := credentials.NewStaticCredentials("accesskey", "secretkey", "")
	sess := session.Must(session.NewSession(&aws.Config{
		Credentials: creds,
		Endpoint:    aws.String("http://localhost:4566"),
		Region:      aws.String("us-east-1"),
	}))
	stsCreds := stscreds.NewCredentials(sess, "arn:aws:iam::000000000000:role/test-data-producer")

	svc := kinesis.New(sess, &aws.Config{
		Credentials: stsCreds,
		Endpoint:    aws.String("http://localhost:4566"),
		Region:      aws.String("us-east-1"),
	})

	// WHEN
	stream := flag.String("s", "purchase", "The stream name")
	partition := flag.String("k", "SHOPxyz", "The partition key")
	payload := flag.String("p", `{"id": "12345", "date_created":"01-01-2023 12:00:00", "description": "Laptop", "amount": 600, "currency": "EUR" }`, "The payload")

	entries := make([]*kinesis.PutRecordsRequestEntry, 1)
	entries[0] = &kinesis.PutRecordsRequestEntry{
		Data:         []byte(*payload),
		PartitionKey: partition,
	}

	inputs := &kinesis.PutRecordsInput{
		Records:    entries,
		StreamName: stream,
	}
	_, err := svc.PutRecords(inputs)

	// THEN
	assert.NilError(t, err, "Kinesis agent failed to put records")
}
