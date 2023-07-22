namespace aggregationTools{

function joinOn ($parameterList,$joinTarget = null) 
{
takes pipeline

returns joinTarget( table that implements join on self)
}

function InnerJoinOn ($parameterList) 
{
takes pipeline

}

function union ($parameterList) 
{
by column index if with null columns if uneven, 
if parameter is specified, except column pairings
flag - no null columns
takes pipeline
}


function except ($parameterList) 
{
takes pipeline
}


function intersect ($parameterList) 
{
takes pipeline
}


function pivot ($parameterList) 
{
aggregates all culumns 
takes pipeline
}

function recursiveJoin ($parameterList) 
{
with for example json
takes pipeline
}

some way to generate set with something in common, for example, index range uniion with rng, is a set that will join with another index set + rng.

}

