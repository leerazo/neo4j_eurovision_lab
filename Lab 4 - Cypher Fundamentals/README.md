# Lab 4 - Cypher Fundamentals
<!---
In this lab, we're going to take data from an Google Cloud Storage bucket and import it into Neo4j.  There are a few different ways to do this.  We'll start with a very naive LOAD CSV statement and then improve it.  

To load it in Neo4j, let's open the tab that has our Neo4j Workspace in it.  If you don't have that tab open, you can review the previous lab to get into it.

Make sure that "Query" is selected at the top.

![](images/01-workspace.png)

-->

You can download the [cypher script for this exercise here](https://storage.googleapis.com/gcp_eurovision_workshop/WorkshopGDS_EurovisionSongContest_Script.cypher). 

So let's start from the beginning!

In Cypher you MATCH a pattern and then RETURN a result

    MATCH (c:Country {name: "Finland"})
    RETURN c;

![](images/02-query1_show_finland.png)

Filtering is done with WHERE (this statement does exactly the same)

    MATCH (c:Country)
    WHERE c.name = "Finland"
    RETURN c;

![](images/03-query2_show_finland.png)

### Using Patterns to Answer Questions
Who won in 1975?

    MATCH (c:Country)<-[vote:VOTE_1975_JURY|VOTE_1975_PUBLIC]-()
    RETURN c.name, sum(vote.weight) as score
    ORDER BY score DESC LIMIT 10;

The Netherlands (with Ding-a-Dong) did and you can check at https://eurovisionworld.com/eurovision/1975, the data is correct.
Please take a moment to note down the positions of Finland, Sweden and Ireland (7, 8, 9), this is going to be useful in a bit.

    MATCH (c:Country)<-[vote:VOTE_2006_JURY|VOTE_2006_PUBLIC]-()
    RETURN c.name, sum(vote.weight) as score
    ORDER BY score DESC LIMIT 10;

Finland (Hard Rock Hallelujah) did (https://eurovisionworld.com/eurovision/2006) … just in case you wondered what the music was about.
