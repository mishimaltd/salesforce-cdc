@SuppressWarnings('PMD.ExcessiveParameterList')
public class ChangeCaptureEvent {

    private final String userName;
    private final String objectType;
    private final String objectId;
    private final String objectName;
    private final String action; 
    private final DateTime createdDate;
    private final Map<String,Object> oldFieldValues;
    private final Map<String,Object> newFieldValues;
    private final Map<String,Object> fullPayload;

    public ChangeCaptureEvent(String userName, 
                              String objectType, 
                              String objectId, 
                              String objectName, 
                              String action, 
                              DateTime createdDate, 
                              Map<String,Object> oldFieldValues, 
                              Map<String,Object> newFieldValues, 
                              Map<String,Object> fullPayload) {
        this.userName = userName;
        this.objectType = objectType;
        this.objectId = objectId;
        this.objectName = objectName;
        this.action = action;
        this.createdDate = createdDate;
        this.oldFieldValues = oldFieldValues;
        this.newFieldValues = newFieldValues;
        this.fullPayload = fullPayload;
    }

    public String getUserName() {
        return userName;
    }

    public String getObjectType() {
        return objectType;
    }

    public String getObjectId() {
        return objectId;
    }

    public String getObjectName() {
        return objectName;
    }

    public String getAction() {
        return action;
    }

    public DateTime getCreatedDate() {
        return createdDate;
    }

    public Map<String,Object> getOldFieldValues() {
        return oldFieldValues;
    }

    public Map<String,Object> getNewFieldValues() {
        return newFieldValues;
    }

    public Map<String,Object> getFullPayload() {
        return fullPayload;
    }

    public class ChangeCaptureEventBuilder {
        private String userName;
        private String objectType; 
        private String objectId;
        private String objectName;
        private String action;
        private DateTime createdDate;
        private Map<String,Object> oldFieldValues;
        private Map<String,Object> newFieldValues;
        private Map<String,Object> fullPayload;

        public ChangeCaptureEventBuilder userName(String userName) {
            this.userName = userName;
            return this;
        }

        public ChangeCaptureEventBuilder objectType(String objectType) {
            this.objectType = objectType;
            return this;
        }

        public ChangeCaptureEventBuilder objectId(String objectId) {
            this.objectId = objectId;
            return this;
        }

        public ChangeCaptureEventBuilder objectName(String objectName) {
            this.objectName = objectName;
            return this;
        }

        public ChangeCaptureEventBuilder action(String action) {
            this.action = action;
            return this;
        }

        public ChangeCaptureEventBuilder createdDate(DateTime createdDate) {
            this.createdDate = createdDate;
            return this;
        }

        public ChangeCaptureEventBuilder oldFieldValues(Map<String,Object> oldFieldValues) {
            this.oldFieldValues = oldFieldValues;
            return this;
        }

        public ChangeCaptureEventBuilder newFieldValues(Map<String,Object> newFieldValues) {
            this.newFieldValues = newFieldValues;
            return this;
        }

        public ChangeCaptureEventBuilder fullPayload(Map<String,Object> fullPayload) {
            this.fullPayload = fullPayload;
            return this;
        }

        public ChangeCaptureEvent build() {
            return new ChangeCaptureEvent(
                userName,
                objectType, 
                objectId,
                objectName,
                action,
                createdDate,
                oldFieldValues,
                newFieldValues,
                fullPayload
            );
        }
    }

}
