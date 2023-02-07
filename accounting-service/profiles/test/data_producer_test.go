package accounting_service_test

import (
	"encoding/json"
	"github.com/PaesslerAG/jsonpath"
	"io"
	"net/http"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/credentials/stscreds"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/firehose"
	"gotest.tools/v3/assert"
)

func RunDataProducerTestsuite(t *testing.T) {
	RunTestGroup(t, "./test_producer", []func(t *testing.T){testDataWrite, testForbiddenWrite})
}

func testDataWrite(t *testing.T) {
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

	endpoint := "http://accounting.us-east-1.es.localhost.localstack.cloud:4566/purchase/_search?pretty"
	client := &http.Client{}
	req, _ := http.NewRequest("GET", endpoint, nil)
	req.Header.Add("Content-Type", "application/json")

	time.Sleep(10 * time.Second) // Wait for records to be written to ES

	res, _ := client.Do(req)
	defer res.Body.Close()

	body, _ := io.ReadAll(res.Body)
	bodyJson := interface{}(nil)
	json.Unmarshal(body, &bodyJson)

	totalHits, _ := jsonpath.Get("$.hits.total.value", bodyJson)

	assert.NilError(t, err, "Could not perform ElasticSearch query")
	assert.Equal(t, float64(2), totalHits.(float64), "ElasticSearch response result count mismatch")
}

func testForbiddenWrite(t *testing.T) {
	// GIVEN
	creds := credentials.NewStaticCredentials("accesskey", "secretkey", "")
	sess := session.Must(session.NewSession(&aws.Config{
		Credentials: creds,
		Endpoint:    aws.String("http://localhost:4566"),
		Region:      aws.String("us-east-1"),
	}))

	producer := firehose.New(sess, &aws.Config{
		Credentials: creds,
		Endpoint:    aws.String("http://localhost:4566"),
		Region:      aws.String("us-east-1"),
	})

	// WHEN
	streamName := "accounting-repair"
	documents := []map[string]interface{}{
		{
			"id":           "123",
			"date_created": "01-01-2023 12:00:00",
			"description":  "Broken TV",
			"value":        600.0,
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
	assert.Error(t, err, "Kinesis agent was able to put records")
}
