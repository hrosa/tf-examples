package accounting_service_test

import (
	"encoding/json"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/credentials/stscreds"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/firehose"
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
	stsCreds := stscreds.NewCredentials(sess, "arn:aws:iam::000000000000:role/accounting-producer")

	producer := firehose.New(sess, &aws.Config{
		Credentials: stsCreds,
		Endpoint:    aws.String("http://localhost:4566"),
		Region:      aws.String("us-east-1"),
	})

	// WHEN
	streamName := "accounting-purchase"
	documents := []map[string]interface{}{
		{
			"id":           "123",
			"date_created": "01-01-2023 12:00:00",
			"description":  "Laptop",
			"value":        600.0,
			"currency":     "EUR",
		},
		{
			"id":           "124",
			"date_created": "01-01-2023 13:00:00",
			"description":  "Smartphone",
			"value":        550.0,
			"currency":     "EUR",
		},
	}
	records := make([]*firehose.Record, 0, len(documents))
	for _, doc := range documents {
		docBytes, _ := json.Marshal(doc)
		records = append(records, &firehose.Record{
			Data: docBytes,
		})
	}

	_, err := producer.PutRecordBatch(&firehose.PutRecordBatchInput{
		DeliveryStreamName: aws.String(streamName),
		Records:            records,
	})

	// THEN
	assert.NilError(t, err, "Kinesis agent failed to put records")
}
