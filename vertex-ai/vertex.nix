{ lib, buildPythonPackage, fetchPypi
, google-api-core
, google-auth
, proto-plus
, protobuf
, packaging
, google-cloud-storage
, google-cloud-bigquery
, google-cloud-resource-manager
, shapely
}:

buildPythonPackage rec {
  pname = "google-cloud-aiplatform";
  version = "1.43.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-vXOvMRqCfnm9IJSlCOk0Oi+nG4rl2PoReNCpbQNLQhs=";
  };

  propagatedBuildInputs = [
    google-api-core
    google-auth
    proto-plus
    protobuf
    packaging
    google-cloud-storage
    google-cloud-bigquery
    google-cloud-resource-manager
    shapely
  ];

  doCheck = false;

  meta = with lib; {
    description = "Vertex AI API client library";
    homepage = "https://github.com/googleapis/python-aiplatform";
    license = licenses.asl20;
    maintainers = with maintainers; [ daniel-fahey ];
  };
}
