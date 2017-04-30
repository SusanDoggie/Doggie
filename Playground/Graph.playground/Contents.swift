//: Playground - noun: a place where people can play

import Cocoa
import Doggie

var graph = Graph<Int, Int>()

graph[from: 1, to: 2] = 0
graph[from: 2, to: 1] = 1

graph[from: 1, to: 2]

graph

graph.linkValues(between: 1, 2)

graph.removeNode(2)

graph
