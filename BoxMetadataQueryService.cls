public class BoxMetadataQueryService {
    private static final String ENDPOINT = 'https://api.box.com/2.0/metadata_queries/execute_read';
    
    public class BoxMetadataQueryRequest {
        public String from { get; set; }
        public String query { get; set; }
        public Map<String, Object> query_params { get; set; }
        public List<String> fields { get; set; }
        public String ancestor_folder_id { get; set; }
        public List<OrderBy> order_by { get; set; }
        public Integer limit_size { get; set; }
        
        public BoxMetadataQueryRequest() {
            this.fields = new List<String>();
            this.query_params = new Map<String, Object>();
            this.order_by = new List<OrderBy>();
        }
    }
    
    public class OrderBy {
        public String field_key { get; set; }
        public String direction { get; set; }
    }
    
    public class BoxMetadataQueryResponse {
        public List<BoxItem> entries { get; set; }
        public Integer limit_value { get; set; }
    }
    
    public class BoxItem {
        public String id { get; set; }
        public String name { get; set; }
        public Map<String, Object> metadata { get; set; }
    }
    
    public BoxMetadataQueryResponse queryByRecordId(String templateKey, String recordId, String accessToken, String folderId) {
        BoxMetadataQueryRequest request = new BoxMetadataQueryRequest();
        
        // Set up the query parameters
        request.from = templateKey; // e.g., 'enterprise_123456.contractTemplate'
        request.query = 'recordId = :recordIdValue';
        request.query_params = new Map<String, Object>{
            'recordIdValue' => recordId
        };
        request.ancestor_folder_id = folderId;
        request.limit_size = 100;
        
        // Add default fields - modify as needed
        request.fields.addAll(new List<String>{
            'name',
            'metadata.' + templateKey + '.recordId'
        });
        
        return executeQuery(request, accessToken);
    }
    
    private BoxMetadataQueryResponse executeQuery(BoxMetadataQueryRequest request, String accessToken) {
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        
        httpRequest.setEndpoint(ENDPOINT);
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Authorization', 'Bearer ' + accessToken);
        httpRequest.setHeader('Content-Type', 'application/json');
        
        // Serialize the request body
        String requestBody = JSON.serialize(request);
        httpRequest.setBody(requestBody);
        
        try {
            HttpResponse response = http.send(httpRequest);
            
            if (response.getStatusCode() == 200) {
                return (BoxMetadataQueryResponse)JSON.deserialize(
                    response.getBody(),
                    BoxMetadataQueryResponse.class
                );
            } else {
                throw new BoxMetadataQueryException('Box API returned status code: ' + 
                    response.getStatusCode() + ' with response: ' + response.getBody());
            }
            
        } catch (Exception e) {
            throw new BoxMetadataQueryException('Error executing Box metadata query: ' + e.getMessage());
        }
    }
    
    public class BoxMetadataQueryException extends Exception {}
}