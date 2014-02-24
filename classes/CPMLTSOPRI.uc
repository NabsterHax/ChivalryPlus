class CPMLTSOPRI extends AOCPRI;

/** Variables so we can transfer score from round to round */
var int PreviousScore;
var int PreviousKill;
var int PreviousDeaths;

function Reset()
{
	PreviousScore = Score;
	PreviousKill = NumKills;
	PreviousDeaths = Deaths;
	super.Reset();
	Score = PreviousScore;
	Kills = PreviousKill;
	Deaths = PreviousDeaths;
}

DefaultProperties
{
	PreviousDeaths=0
	PreviousScore=0
	PreviousKill=0
}
