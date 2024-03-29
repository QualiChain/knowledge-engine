# DeTrusty

DeTrusty is a federated query engine.
At this stage, only SPARQL endpoints are supported.
DeTrusty differs from other query engines through its focus on the explainability and trustworthiness of the query result.

**Notice: DeTrusty is under active development! 
The current version is a federated query engine following the SPARQL 1.1 protocol, i.e., you can use the SERVICE clause to specify the endpoint.
However, the parts about the explainability and trustworthiness have not been implemented yet.
Additionally, the GROUP BY operator as well as aggregates have not yet been implemented.**

## Running DeTrusty
In order to run DeTrusty, build the Docker image from the source code:

``docker build . -t sdmtib/detrusty:v0.3.1-qc``

Once the Docker image is built, you can start DeTrusty:

``docker run --name DeTrusty -d -p 5000:5000 sdmtib/detrusty:v0.3.1-qc``

You can now start to make POST requests to the DeTrusty API running at localhost:5000.

## Configuring DeTrusty
In order to setup the federation of endpoints that will be queried by DeTrusty follow these instructions.
1. create a file including the URLs of the endpoints (one per line)
1. inside the container: place this file in `/DeTrusty/Config/endpoints.txt`
1. inside the container: run `create_rdfmts.py -s /DeTrusty/Config/endpoints.txt`
1. once it is done collecting the source descriptions, restart the container

## DeTrusty API
You can use DeTrusty by making POST requests to its API.
In the following, the different API calls are described.

### /version
Returns the version number of DeTrusty.

Example call:

```bash
curl -X POST localhost:5000/version
```

Example output:

``DeTrusty v0.3.0-qc``

### /sparql
This API call is used to send a query to the federation and retrieve the result.
The result will be returned as a JSON (see example below).

Example call (see below this example for an example using private data stores):

```bash
curl -X POST -d "query=SELECT ?s WHERE { ?s a <http://dbpedia.org/ontology/Scientist> } LIMIT 10" localhost:5000/sparql
```

Example output for the above query (shortened to two results):

```yaml
{
  "cardinality": 10,
  "execution_time": 0.1437232494354248,
  "output_version": "2.0",
  "head": { "vars": ["s"] },
  "results": {
    "bindings": [
      {
        "__meta__": { "is_verified": True },
        "s": {
          "type": "uri",
          "value": "http://dbpedia.org/resource/A.E._Dick_Howard"
        }
      },
      {
        "__meta__": { "is_verified": True },
        "s": {
          "type": "uri",
          "value": "http://dbpedia.org/resource/A.F.P._Hulsewé"
        }
      },
    ]
  }
}
```
'cardinality' is the number (integer) of results retrieved,
'execution_time' (float) gives the time in seconds the query engine has spent collecting the results,
'output_version' (string) indicates the version number of the output format, i.e., to differentiate the current output from possibly changed output in the future,
'vars' (list) in 'head' returns a list of the variables found in the query,
'bindings' in 'results' is a list of dictionaries containing the results of the query, using the variables as keys. The type and value of the binding of the variable are returned in 'type' and 'value', respectively.
Metadata about the result verification is included in the key '\_\_meta\_\_'.
The current version returns all results as verified as can be seen in the key 'is_verified' of the metadata.

**If you want to query private data that is stored in a Solid Pod, you need to use the SPARQL 1.1 Service clause and add additional information to your request:**
```bash
curl -X POST -d "query=SELECT DISTINCT ?c WHERE { SERVICE <URL_OF_THE_POD_YOU_WANT_TO_QUERY> { ?s a ?c } }" -d "sparql1_1=True" -d "token=YOUR_QC_AUTH_TOKEN" localhost:5000/sparql
```

## License
DeTrusty is licensed under GPL-3.0.
