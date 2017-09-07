module gameoflife.game;

import std.stdio;
import std.math;
import dunit.toolkit;

struct Cell {
	long x;
	long y;
}

alias Cell[] CellList;

/// Count cell neighbours
long neighbours(Cell myCell, CellList list) {
	long cnt;

	foreach(cell; list) {
		auto diff1 = abs(myCell.x - cell.x);
		auto diff2 = abs(myCell.y - cell.y);

		if(diff1 == 1 || diff2 == 1) cnt++;
	}

	return cnt;
}

unittest {
	CellList world = [ ];
	assertEqual(Cell(1,1).neighbours(world), 0);
}

unittest {
	CellList world = [ Cell(0,0), Cell(0,1), Cell(0,2), Cell(1,0), Cell(1,2), Cell(2,0), Cell(2,1), Cell(2,2) ];
	assertEqual(Cell(1,1).neighbours(world), world.length);
}

unittest {
	CellList world = [ Cell(0,0), Cell(1,1), Cell(2,2), Cell(3,3) ];
	assertEqual(Cell(1,1).neighbours(world), 2);
}


/// Remove a cell from the world
CellList remove(ref CellList list, Cell myCell) {
	CellList newList;

	foreach(cell; list)
		if(cell != myCell)
			newList ~= cell;

	list = newList;

	return newList;
}

unittest {
	CellList world = [ Cell(1,1), Cell(1,2) ];

	assertEqual(world.remove(Cell(1,1)).length, 1);
}


/// Check if a cell lives
bool livesIn(Cell myCell, CellList list) {

	foreach(cell; list)
		if(cell == myCell) return true;

	return false;
}

unittest {
	CellList world = [ Cell(1,1) ];

	assertTrue(Cell(1,1).livesIn(world));
}

unittest {
	CellList world = [ Cell(1,1) ];

	assertFalse(Cell(2,2).livesIn(world));
}

/// Get a list of all dead neighbours
CellList deadNeighbours(Cell myCell, CellList list) {
	CellList newList;

	foreach(x; myCell.x-1..myCell.x+1)
		foreach(y; myCell.y-1..myCell.y+1)
			if(x != myCell.x && y != myCell.y && !Cell(x,y).livesIn(list))
				newList ~= Cell(x,y);

	return newList;
}

/// The function that moves our cells to the next generation
void evolve(ref CellList list) {
	CellList newList = list;

	foreach(cell; list) {
		if(cell.neighbours(list) < 2)
			newList.remove(cell);

		if(cell.neighbours(list) > 3)
			newList.remove(cell);

		auto deadFrirends = cell.deadNeighbours(list);

		foreach(friend; deadFrirends)
			if(friend.neighbours(list) == 3)
				newList ~= friend;
	}

	list = newList;
}


//Any live cell with fewer than two live neighbours dies,
//as if caused by under-population.
unittest {
	CellList world = [ Cell(1,1), Cell(0,0) ];

	world.evolve;

	assertEqual(world.length, 0);
}

//Any live cell with two or three live neighbours lives
//on to the next generation.
unittest {
	CellList world = [ Cell(1,1), Cell(0,0), Cell(0,1) ];

	world.evolve;

	assertTrue( Cell(1,1).livesIn(world) );
}

//Any live cell with more than three live neighbours dies,
//as if by overcrowding.
unittest {
	CellList world = [ Cell(0,0), Cell(0,1), Cell(1,1), Cell(2,1), Cell(2,2) ];

	world.evolve;

	assertFalse( Cell(1,1).livesIn(world) );
}

//Any dead cell with exactly three live neighbours becomes
//a live cell, as if by reproduction.
unittest {
	CellList world = [ Cell(0,1), Cell(2,1), Cell(2,2) ];

	world.evolve;

	assertTrue( Cell(1,1).livesIn(world) );
}
