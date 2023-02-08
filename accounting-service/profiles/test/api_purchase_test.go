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

func RunApiPurchasesTestsuite(t *testing.T) {
	RunTestGroup(t, "./test_api_purchase", []func(t *testing.T){readDataScenario})
}

func readDataScenario(t *testing.T) {
	// GIVEN
	// Get contextual data from TF output
	terraformOptions := &terraform.Options{
		TerraformDir:       "./test_api_purchase",
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
	payload := []byte(`{"id": "12345", date_created: "01-01-2023 12:00:00", "item_name": "Laptop xyz", "price": 600.0, "currency": "EUR"}`)
	req, _ := http.NewRequest(http.MethodPost, "http://"+esEndpoint+"/purchase/_doc", bytes.NewReader(payload))
	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("Accept", "application/json")

	client := &http.Client{}
	client.Do(req)

	// WHEN
	req, _ = http.NewRequest(http.MethodGet, "http://"+apiId+".execute-api.localhost.localstack.cloud:4566/"+stageId+"/accounting/purchases", nil)
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
	println(esDoc)
	assert.Assert(t, strings.Contains(esDoc.(string), `"id": "12345"`))

}
