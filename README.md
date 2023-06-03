# Hands-on Lab Neo4j on Google Cloud 
Neo4j is the [leading graph database](https://db-engines.com/en/ranking/graph+dbms) vendor.  We’ve worked closely with Google Cloud engineering for years.  Our products, AuraDB and AuraDS are offered as managed services on Google Cloud.  Neo4j Enterprise Edition, which includes Graph Database, Graph Data Science and Bloom is offered in the [Google Cloud Marketplace](https://console.cloud.google.com/marketplace/browse?q=neo4j).

In this hands on lab, you’ll get to learn about [Neo4j](https://neo4j.com/) on [Google Cloud](https://cloud.google.com/). You will configure and deploy an instance using [Aura](https://console.cloud.google.com/marketplace/product/endpoints/prod.n4gcp.neo4j.io) which is Neo4j's fully managed graph database offering. 

We’ll walk through deploying a Neo4j AuraDS instance in your Google Cloud account. Then we’ll load a samle data set into the database and explore it using cypher and our Graph Data Science (GDS) graph algorithm library. 

## Duration
1 hour

## Prerequisites
You'll need a laptop with a web browser.  Your browser will need to be able to access the Google Cloud Console and port 7474 on a Neo4j deployment running on Google Cloud.  If your laptop has a firewall you can't control on it, you may want to bring your personal laptop.

If you have a Google Cloud account with permissions that allow you to invoke Neo3j AuraDS, deploy from Marketplace and create a Cloud Storage bucket, then you can use that.  If not, we'll walk you through creating a Google Cloud account.

## Agenda
* Introductions
* Lecture - [Introduction to Neo4j](https://console.cloud.google.com/marketplace/product/endpoints/prod.n4gcp.neo4j.io) (10 min)
    * What is Neo4j?
    * How is it deployed and managed on Google Cloud?
    * Neo4j Overview
    * Graph Data Sciece Overview
* [Lab 1 - Deploy Neo4j on Google cloud](Lab%201%20-%20Deploy%20Neo4j) (15 min)
    * Deploying Neo4j AuraDS Professional
* [Lab 2 - Connect to Neo4j](Lab%202%20-%20Connect%20to%20Neo4j/README.md) (10 min)
    * Neo4j Workspace
* [Lab 3 - Load Database into Neo4j AuraDS](Lab%203%20-%20Load%20Database%20into%20Neo4j%20AuraDS/README.md) (15 min)

Lab%203%20-%20Moving%20Data/README.md) (15 min)
    * A Day of Data
    * A Year of Data
* [Lab 4 - Exploration](Lab%204%20-%20Exploration/README.md) 10 min)
    * Exploration with Neo4j Bloom
* [Lab 5 - Vertex AI Workbench](Lab%205%20-%20Vertex%20AI%20Workbench/README.md) 15 min)
    * Pandas
    * Vertex AI Workbench
    * Cypher Queries
* Break (10 min)

### Part 3
* Lecture - [Graph Data Science](https://docs.google.com/presentation/d/133tXAH--V7Uvyd0Ylhs08_xDEPfl64uvaNNdxeHVpvk/edit?usp=sharing) (10 min)
    * Why Graph Data Science
    * Neo4j GDS
    * Algorithm Families and Examples
    * Similarity
    * Centrality
    * Community Detection
    * Graph Machine Learning
* [Lab 6 - Graph Data Science](Lab%206%20-%20Graph%20Data%20Science/README.md) (15 min)
    * Creating a Graph Embedding
    * Exporting to pandas
    * Writing to Google Cloud Storage
* Lecture - [Vertex AI](https://docs.google.com/presentation/d/19TewJE5YgESTmN9qW4MOtFP4m39uPhUaRXErkCzrdbE/edit?usp=sharing) (10 min)
    * What is Vertex AI?
    * Using Vertex AI with Neo4j
* [Lab 7 - Vertex AI AutoML](Lab%207%20-%20Vertex%20AI%20AutoML) (15 min)
    * Raw Data
    * Data with Embedding
* [Lab 8 - Cleanup](Lab%208%20-%20Cleanup) (5 min)
* [Discussion - Questions and Next Steps](Discussion%20-%20Questions%20and%20Next%20Steps.md) (5 min)
