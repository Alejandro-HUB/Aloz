const username = "admin";
const password = "L645cceZCBY6aWDn";
const clusterUrl = "54.89.169.138:27017";
const clusterName = "CRM";
const authMechanism = "SCRAM-SHA-256";
const authSource = "admin";

const MONGO_CONN_URL = "mongodb://${username}:${password}@${clusterUrl}/${clusterName}?authMechanism=${authMechanism}&authSource=${authSource}";
const USER_COLLECTION = "Contacts";
