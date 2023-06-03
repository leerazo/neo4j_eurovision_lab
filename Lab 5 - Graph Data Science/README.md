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

Project the relevant data into the in-memory workspace
    CALL gds.graph.project("eurosong1975",
      "Country",
      "VOTE_1975_JURY",
      { relationshipProperties: "weight" }
    ) YIELD graphName, nodeCount, relationshipCount
    RETURN graphName, nodeCount, relationshipCount;

Something is not quite right, check https://eurovisionworld.com/eurovision/1975 again, how many countries participated? 

