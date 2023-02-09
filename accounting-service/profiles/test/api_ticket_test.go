package accounting_service_test

import (
	"bytes"
	"encoding/json"
	"github.com/PaesslerAG/jsonpath"
	"gotest.tools/v3/assert"
	"io"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func RunApiTicketsTestsuite(t *testing.T) {
	RunTestGroup(t, "./test_api_ticket", []func(t *testing.T){queryAllTickets, queryTicketById})
}

func queryAllTickets(t *testing.T) {
	// GIVEN
	// Get contextual data from TF output
	terraformOptions := &terraform.Options{
		TerraformDir:       "./test_api_ticket",
		Lock:               false,
		Upgrade:            true,
		MaxRetries:         1,
		MigrateState:       true,
		TimeBetweenRetries: 5 * time.Second,
	}
	outputs := terraform.OutputAll(t, terraformOptions)
	t.Logf("Terraform output %v", outputs)

	apiId := outputs["api_id"].(string)
	stageId := outputs["api_stage_name"].(string)
	esEndpoint := outputs["datastore_endpoint"].(string)

	// Provision ElasticSearch records
	payload := []byte(`{"id": "12345", "issued_on": "01-01-2023 12:00:00", "event_name": "Concert X", "event_date": "03-03-2023 21:00:00", "event_location": "Arena Z", "price": 45.0, "currency": "EUR"}`)
	req, _ := http.NewRequest(http.MethodPost, "http://"+esEndpoint+"/ticket/_doc", bytes.NewReader(payload))
	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("Accept", "application/json")

	client := &http.Client{}
	client.Do(req)

	// WHEN
	req, _ = http.NewRequest(http.MethodGet, "http://"+apiId+".execute-api.localhost.localstack.cloud:4566/"+stageId+"/accounting/tickets", nil)
	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("Accept", "application/json")
	req.Header.Add("Authorization", "Basic 1234567890")

	res, _ := client.Do(req)
	body, err := io.ReadAll(res.Body)

	// THEN
	assert.NilError(t, err, "Could not make API request")

	bodyJson := interface{}(nil)
	json.Unmarshal(body, &bodyJson)

	statusCode, _ := jsonpath.Get("$.statusCode", bodyJson)
	assert.Equal(t, float64(200), statusCode.(float64), "Status Code mismatch")

	esDoc, _ := jsonpath.Get("$.body", bodyJson)
	println(esDoc.(string))
	assert.Assert(t, strings.Contains(esDoc.(string), `"id" : "12345"`))
}

func queryTicketById(t *testing.T) {
	// GIVEN
	// Get contextual data from TF output
	terraformOptions := &terraform.Options{
		TerraformDir:       "./test_api_ticket",
		Lock:               false,
		Upgrade:            true,
		MaxRetries:         1,
		MigrateState:       true,
		TimeBetweenRetries: 5 * time.Second,
	}
	outputs := terraform.OutputAll(t, terraformOptions)
	t.Logf("Terraform output %v", outputs)

	apiId := outputs["api_id"].(string)
	stageId := outputs["api_stage_name"].(string)
	esEndpoint := outputs["datastore_endpoint"].(string)

	// Provision ElasticSearch records
	payload := []byte(`{"id": "11111", "issued_on": "01-01-2023 12:00:00", "event_name": "Theatre Play X", "event_date": "05-04-2023 21:00:00", "event_location": "Theatre Y", "price": 20.0, "currency": "EUR"}`)
	req, _ := http.NewRequest(http.MethodPost, "http://"+esEndpoint+"/ticket/_doc", bytes.NewReader(payload))
	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("Accept", "application/json")

	client := &http.Client{}
	client.Do(req)

	// WHEN
	req, _ = http.NewRequest(http.MethodGet, "http://"+apiId+".execute-api.localhost.localstack.cloud:4566/"+stageId+"/accounting/tickets/11111", nil)
	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("Accept", "application/json")
	req.Header.Add("Authorization", "Basic 1234567890")

	res, _ := client.Do(req)
	body, err := io.ReadAll(res.Body)

	// THEN
	assert.NilError(t, err, "Could not make API request")

	bodyJson := interface{}(nil)
	json.Unmarshal(body, &bodyJson)

	statusCode, _ := jsonpath.Get("$.statusCode", bodyJson)
	assert.Equal(t, float64(200), statusCode.(float64), "Status Code mismatch")

	esDoc, _ := jsonpath.Get("$.body", bodyJson)
	println(esDoc.(string))
	assert.Assert(t, strings.Contains(esDoc.(string), `"id" : "11111"`))
}
