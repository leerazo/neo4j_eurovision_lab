# Lab 5 - Graph Data Science 

#### Using Algorithms to Anser Questions
A typical run of a graph algorithm has the following steps:
1. Know your data. Run some statistics. This will help determine if the results make sense. Run some estimates. Do you have enough memory?
2. Project the necessary data into the in-memory workspace. 
3. Run the algorithm in estimate mode. Run it in stats mode. See 1. for the reason.
4. Run the algorithm. Handle the results.
5. Remove the projection if it is no longer needed.

In this lab we will focus on 2. and 4. (to save time and reduce complexity) but please do not forget the other steps once you are doing this on your own. 

**Who won in 1975?**

This question is asking about the importance of countries in our voting graph. That's a centrality problem and the best known algorithm for it is pageranking so let's apply that!
Project the relevant data into the in-memory workspace

Project the relevant data into the in-memory workspace.

    CALL gds.graph.project("eurosong1975",
      "Country",
      "VOTE_1975_JURY",
      { relationshipProperties: "weight" }
    ) YIELD graphName, nodeCount, relationshipCount
    RETURN graphName, nodeCount, relationshipCount;

Something is not quite right, check https://eurovisionworld.com/eurovision/1975 again, how many countries participated? 

Show an overview of the projections
    CALL gds.graph.list();

Clean up the projection
    CALL gds.graph.drop("eurosong1975");

And try it in a different way …

    CALL gds.graph.project.cypher("eurosong1975",
      "MATCH (c:Country) WHERE EXISTS ((c)-[:VOTE_1975_JURY]-()) RETURN id(c) as id, labels(c) as labels",
      "MATCH (s:Country)-[r:VOTE_1975_JURY]->(t:Country) RETURN id(s) as source, id(t) as target, type(r) as type, r.weight as weight"
    ) YIELD graphName, nodeCount, relationshipCount
    RETURN graphName, nodeCount, relationshipCount;

Native projection VERSUS Cypher projection
-  Native projection is very efficient, scales to huge graphs
-  Native projection requires that your original graph is completely tailored to the problems
-  Cypher projection is less efficient
-  Cypher projection gives you full flexibility (you can even project things that aren't there)

For our hands-on we'll go with Cypher projections, but do keep above in mind!

Streaming the results for 1975

    CALL gds.pageRank.stream("eurosong1975", {
      maxIterations: 20,
      dampingFactor: 0.85,
      relationshipWeightProperty: "weight"
    }) YIELD nodeId, score
    RETURN gds.util.asNode(nodeId).name AS name, score
    ORDER BY score DESC, name ASC LIMIT 10;

Streaming the results for 1975


Does anybody notice something strange about positions 7, 8 and 9?

![](images/01-fin_swe_ire.png)

**A bit of a rant**

Why aren't Finland, Ireland and Sweden in the correct order? Is pageranking giving us information that a plain score can not? Yes and no.

The way pageranking works is that incoming votes are only part of the story. A vote gets more importance if it comes from a page that itself has a high score. Ireland got votes from The Netherlands. The others did not.

The lesson here is that you
- Need to understand your data
- Need to understand the algorithms 

**Let's up the ante**

Going back to the Scandinavian myth…
What were the voting communities in 1975?

    CALL gds.louvain.stream("eurosong1975", {
     relationshipWeightProperty: "weight"
    }) YIELD nodeId, communityId
    RETURN collect(gds.util.asNode(nodeId).name) AS members, communityId
    ORDER BY communityId DESC

Nice, but without looking over all the years there's no way to bust the Scandinavian myth …

Project the remaining years without televoting

    UNWIND range(1976,2015,1) as year
    CALL {
    WITH year
    CALL gds.graph.project.cypher("eurosong" + year,
        "MATCH (c:Country) WHERE EXISTS ((c)-[:VOTE_" + year + "_JURY]-()) RETURN id(c) as id, labels(c) as labels",
        "MATCH (s:Country)-[r:VOTE_" + year + "_JURY]->(t:Country) RETURN id(s) as source, id(t) as target, type(r) as type, r.weight as weight"
    ) YIELD graphName  
    RETURN graphName
    }
    RETURN year, graphName;

Project the remaining years with televoting

    UNWIND range(2016,2018,1) as year
    CALL {
    WITH year
    CALL gds.graph.project.cypher("eurosong" + year,
        "MATCH (c:Country) WHERE EXISTS ((c)-[:VOTE_" + year + "_JURY]-()) RETURN id(c) as id, labels(c) as labels",
        "MATCH (s:Country)-[r:VOTE_" + year + "_JURY|VOTE_" + year + "_PUBLIC]->(t:Country) RETURN id(s) as source, id(t) as target, type(r) as type, r.weight as weight"
    ) YIELD graphName  
    RETURN graphName
    }
    RETURN year, graphName;

Run Louvain in bulk and mutate the in-memory projection

    UNWIND range(1975,2018,1) as year
    CALL {
    WITH year
    CALL gds.louvain.mutate("eurosong" + year, {
        relationshipWeightProperty: "weight",
        mutateProperty: "louvain" + year
    }) YIELD nodePropertiesWritten
    RETURN nodePropertiesWritten
    }
    RETURN year, nodePropertiesWritten;

There are three main modes (ignoring stats and estimate) to run an algorithm

- **stream** - streams the results and is typically either used as a test run (with visual inspection of the results) or when you want to use the results outside of Neo4j (in a machine learning pipeline for example)

- **write** - modifies the original graph, which can be very useful if you want to combine analytics with real time use cases

- **mutate** - modifies the in-memory projection, which is typically done when you have a chain of algorithms where one has to feed into the next