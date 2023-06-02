//-------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------ WORKSHOP GDS
//------------------------------------------------------------------------- EUROVISION SONG CONTEST
//------------------------------------------------ https://tinyurl.com/eurovisionsongcontest-script
//-------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------- Marco Bessi
//-------------------------------------------------------------------------------------------------

//---- This set of queries/algos work correctly with WorkshopGDS_EurovisionSongContest_Dump550.dump 
//---- on Neo4j v5.5.0, APOC v5.5.0 and GDS v2.3.2. -----------------------------------------------
//---- Download the dump here: https://tinyurl.com/eurovisionsongcontest-dump550 ------------------

//-------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------ Cypher

//00.FirstCypher
MATCH (c:Country {name:"Finland"}) RETURN c;


//01.WhoWon1975
MATCH (c:Country)<-[vote:VOTE_1975_JURY]-() 
RETURN c.name, sum(vote.weight) as score
ORDER BY score DESC LIMIT 10;


//02.WhoWon2006
MATCH (c:Country)<-[vote:VOTE_2006_JURY|VOTE_2006_PUBLIC]-()
RETURN c.name, sum(vote.weight) as score
ORDER BY score DESC LIMIT 10;


//03.CountryXAlwaysVotoForCountryY
MATCH (target:Country)<-[r]-() 
WHERE NOT type(r) IN ['SPLIT_INTO','WAS_RENAMED']
  AND NOT type(r) CONTAINS 'PUBLIC'
WITH target, count(DISTINCT type(r)) AS totalentries
WHERE totalentries > 15
MATCH (target)<-[r]-(source:Country)
WHERE NOT type(r) IN ['SPLIT_INTO','WAS_RENAMED']
  AND NOT type(r) CONTAINS 'PUBLIC'
WITH target, source, count(r) as votes, totalentries
WHERE votes > totalentries * 0.80
RETURN source.name AS `country-X`, target.name as `country-Y`, votes, totalentries, toFloat(votes)/toFloat(totalentries) as percentage
ORDER BY votes+totalentries DESC;


//-------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------- GDS

//04.CreateNativePrj
CALL gds.graph.project("eurosong1975",
    "Country",
    "VOTE_1975_JURY",
    { relationshipProperties: "weight" }
) YIELD graphName, nodeCount, relationshipCount
RETURN graphName, nodeCount, relationshipCount;


//05.DropNativePrj
CALL gds.graph.drop("eurosong1975");


//06.CreateCypherPrj
CALL gds.graph.project.cypher("eurosong1975",
    "MATCH (c:Country) WHERE EXISTS ((c)-[:VOTE_1975_JURY]-()) RETURN id(c) as id, labels(c) as labels",   
    "MATCH (s:Country)-[r:VOTE_1975_JURY]->(t:Country) RETURN id(s) as source, id(t) as target, type(r) as type, r.weight as weight"
) YIELD graphName, nodeCount, relationshipCount
RETURN graphName, nodeCount, relationshipCount;


//07.PageRankStream
CALL gds.pageRank.stream("eurosong1975", {
    maxIterations: 20,
    dampingFactor: 0.85,
    relationshipWeightProperty: "weight"
}) YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC, name ASC LIMIT 10;


//08.VotingCommunities1975-LouvainStream
CALL gds.louvain.stream("eurosong1975", {
    relationshipWeightProperty: "weight"
}) YIELD nodeId, communityId
RETURN collect(gds.util.asNode(nodeId).name) AS members, communityId
ORDER BY communityId DESC


//09.CreatingAllPrjs
//Without televote
UNWIND range(1976,2015,1) as year
CALL {
    WITH year
    CALL gds.graph.project.cypher("eurosong" + year,
        "MATCH (c:Country) WHERE EXISTS ((c)-[:VOTE_" + year + "_JURY]-()) RETURN id(c) as id, labels(c) as labels",
        "MATCH (s:Country)-[r:VOTE_" + year + "_JURY]->(t:Country) RETURN id(s) as source, id(t) as target, type(r) as type, r.weight as weight"
    ) YIELD graphName
    RETURN graphName
} RETURN year, graphName;

//With televote
UNWIND range(2016,2018,1) as year
CALL {
    WITH year
    CALL gds.graph.project.cypher("eurosong" + year,
        "MATCH (c:Country) WHERE EXISTS ((c)-[:VOTE_" + year + "_JURY]-()) RETURN id(c) as id, labels(c) as labels",
        "MATCH (s:Country)-[r:VOTE_" + year + "_JURY|VOTE_" + year + "_PUBLIC]->(t:Country) RETURN id(s) as source, id(t) as target, type(r) as type, r.weight as weight"
    ) YIELD graphName
    RETURN graphName
} RETURN year, graphName;


//10.RunLouvainMutateOnAll
UNWIND range(1975,2018,1) as year
CALL {
    WITH year
    CALL gds.louvain.mutate("eurosong" + year, {
        relationshipWeightProperty: "weight",
        mutateProperty: "louvain" + year
    }) YIELD nodePropertiesWritten
    RETURN nodePropertiesWritten
} RETURN year, nodePropertiesWritten


//10b.WriteBackLouvainPropertiesOnDB
UNWIND range(1975,2018,1) as year
CALL {
    WITH year
    CALL gds.graph.nodeProperties.write("eurosong"+year, ['louvain'+year], ['Country']) 
    YIELD propertiesWritten RETURN propertiesWritten
} RETURN year, propertiesWritten


//11.GeneratingYearXNodesAndRelatedRelationships
//Creating nodes for each community in each year
UNWIND range(1975,2018,1) as year1
CALL {
    WITH year1
    CALL apoc.cypher.run("MATCH (c:Country) RETURN collect(distinct c.louvain"+year1+") as comms", {})
    YIELD value
    WITH year1, value.comms as yearCommunities
    UNWIND yearCommunities as yC
    CALL apoc.merge.node(["Year"+year1], {value: yC})
    YIELD node
    RETURN count(node) as nodeWritten1
} RETURN year1, nodeWritten1;

//Creating relationships between Country and YearX
UNWIND range(1975,2018,1) as year2
CALL {
    WITH year2
    CALL apoc.cypher.run("MATCH (c:Country) WHERE c.louvain"+year2+" IS NOT NULL RETURN c as node, c.louvain"+year2+" as community", {})
    YIELD value as c
    WITH year2, c
    CALL apoc.cypher.run("MATCH (y:Year"+year2+") WHERE y.value = "+c.community+" RETURN y as node", {})
    YIELD value as y
    WITH year2, c, y
    CALL apoc.create.relationship(c.node, "HAS_COMMUNITY", {}, y.node)
    YIELD rel
    RETURN count(rel) as nodeWritten2
} RETURN year2, nodeWritten2;


//12.ProjectingForNodeSimilarity
CALL gds.graph.project("eurosong_communities",
    ['Country','Year1975', 'Year1976', 'Year1977', 'Year1978', 'Year1979',  'Year1980', 'Year1981', 'Year1982', 'Year1983', 'Year1984', 'Year1985', 'Year1986', 'Year1987', 'Year1988', 'Year1989', 'Year1990', 'Year1991', 'Year1992', 'Year1993', 'Year1994', 'Year1995', 'Year1996', 'Year1997', 'Year1998', 'Year1999', 'Year2000', 'Year2001', 'Year2002', 'Year2003', 'Year2004', 'Year2005', 'Year2006', 'Year2007', 'Year2008', 'Year2009', 'Year2010', 'Year2011', 'Year2012', 'Year2013', 'Year2014', 'Year2015', 'Year2016', 'Year2017', 'Year2018'],
    "HAS_COMMUNITY"
) YIELD graphName, nodeCount, relationshipCount
RETURN graphName, nodeCount, relationshipCount;


//13.RunNodeSimilarityToCreateSIMILAR_TO
CALL gds.nodeSimilarity.write('eurosong_communities', {
    writeRelationshipType: 'SIMILAR_TO',
    writeProperty: 'score',
    similarityCutoff: 0.5
})
YIELD nodesCompared, relationshipsWritten


//14.ShowSimilarCountries
MATCH p=(:Country)-[r:SIMILAR_TO]->(:Country) 
WHERE r.score>0.5 
RETURN p;


//-------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------- DROP TO CLEAN AND RESTART

//15.DropNSProjection
CALL gds.graph.drop('eurosong_communities')

//15b.DropLouvainProjections
UNWIND range(1975,2018,1) as year
CALL {
    WITH year
    CALL gds.graph.drop('eurosong'+year, false) 
    YIELD graphName RETURN graphName
} RETURN count(graphName);


//15c.DeleteYears
UNWIND range(1975,2018,1) as year1
CALL {
    WITH year1
    CALL apoc.cypher.runWrite("MATCH (y:Year"+year1+") DETACH DELETE y", {})
    YIELD value
    RETURN count(value) as nodeDeleted
} RETURN year1, nodeDeleted;


//15d.DeleteLouvainProperties
UNWIND range(1975,2018,1) as year
CALL {
    WITH year
    CALL apoc.cypher.runWrite("MATCH (c:Country) WHERE c.louvain"+year+" IS NOT NULL REMOVE c.louvain"+year, {})
    YIELD value
    RETURN count(value) as propertiesDeleted
} RETURN year, propertiesDeleted;


//15e.DeleteSIMILARTO
MATCH p=()-[r:SIMILAR_TO]->() DELETE r