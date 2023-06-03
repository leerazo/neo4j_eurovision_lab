# Lab 6 - Clean Up

First delete the projections from memory

    CALL gds.graph.drop('eurosong_communities')

    UNWIND range(1975,2018,1) as year
    CALL {
        WITH year
        CALL gds.graph.drop('eurosong'+year, false) 
        YIELD graphName RETURN graphName
    } RETURN count(graphName);

Next renove relationships

    MATCH p=()-[r:SIMILAR_TO]->() DELETE r
 
Remove the year nodes
 
    UNWIND range(1975,2018,1) as year
    CALL {
        WITH year
        CALL apoc.cypher.runWrite("MATCH (y:Year"+year1+") 
			        DETACH DELETE y", {})
        YIELD value RETURN count(value) as nodeDeleted
    } RETURN year1, nodeDeleted;

Remove the detected communities
 
    UNWIND range(1975,2018,1) as year
    CALL {
        WITH year
        CALL apoc.cypher.runWrite("MATCH (c:Country) 
    WHERE c.louvain"+year+" IS NOT NULL REMOVE c.louvain"+year, {})
        YIELD value RETURN count(value) as propertiesDeleted
    } RETURN year, propertiesDeleted;