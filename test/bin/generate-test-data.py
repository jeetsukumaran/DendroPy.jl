#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import dendropy
import random
import json

def add_tree_features_(tree, tree_idx):
    tree.key = f"Tree{tree_idx:03d}"
    tree = add_node_data(tree, tree.key)
    tree.resolve_node_ages()
    tree.resolve_node_depths()
    return tree

def add_node_data(tree, tree_key):
    ind_index = 1
    for nd_idx, nd in enumerate(tree):
        nd.key = ".".join([tree_key, f"Node{nd_idx+1:03d}"])
        if nd._child_nodes:
            nd.label = f"I{ind_index:03d}"
            ind_index += 1
    return tree

def extract_tree_features(tree):
    tree_d = {}
    tree_d["key"] = tree.key
    tree_d["nodes"] = {}
    tree_d["definitions"] = {
        "nexus": tree.as_string("nexus"),
        "newick": tree.as_string("newick"),
    }
    for feature_class in (
        ( "keys", lambda nd: nd.key, ),
        ( "edge_lengths", lambda nd: nd.edge.length if nd.edge.length else 0.0, ),
        ( "labels", lambda nd: nd.taxon.label if nd.taxon else nd.label, ),
        ( "ages", lambda nd: nd.age, ),
        ( "depths", lambda nd: nd.depth, ),
        ( "parents", lambda nd: [nd.parent_node.key] if nd.parent_node else [], ),
        ( "children", lambda nd: [chnd.key for chnd in nd.child_nodes()] if not nd.is_leaf else [], ),
    ):
        feature_key = feature_class[0]
        feature_fn = feature_class[1]
        tree_d["nodes"][feature_key] = {}
        tree_d["nodes"][feature_key]["postorder"] = [feature_fn(nd) for nd in tree.postorder_node_iter()]
        tree_d["nodes"][feature_key]["preorder"] = [feature_fn(nd) for nd in tree.preorder_node_iter()]
        tree_d["nodes"][feature_key]["leaves"] = [feature_fn(nd) for nd in tree.leaf_nodes()]
        tree_d["nodes"][feature_key]["internal"] = [feature_fn(nd) for nd in tree.internal_nodes()]
    tree_d["features"] = {
        "length": sum(edge.length if edge.length else 0.0 for edge in tree.postorder_edge_iter()),
        "n_leaves": sum(1 for nd in tree.leaf_node_iter()),
        "n_internal": sum(1 for nd in tree.internal_nodes()),
        "coalescence_ages": sorted([nd.age for nd in tree.internal_nodes()]),
        "divergence_times": sorted([nd.depth for nd in tree.internal_nodes()]),
    }
    return tree_d

def export_tree_features(out, d):
    out.write(json.dumps(d, indent=4))
    out.write("\n")

def generate_test_data_trees(
    out,
    random_seed=None,
):
    rng = random.Random(random_seed)
    tree_idx = 1
    d = {}
    d["data"] = []
    trees = []
    for leaf_set_size in range(2, 24):
        leaf_labels = [f"T{idx:03d}" for idx in range(leaf_set_size)]
        tns = dendropy.TaxonNamespace(leaf_labels)
        tree = dendropy.simulate.pure_kingman_tree(tns)
        tree = add_tree_features_(tree, tree_idx)
        features = extract_tree_features(tree)
        d["data"].append(features)
        trees.append(tree)
        tree_idx += 1
    tree_list = dendropy.TreeList()
    for tree in trees:
        tree_list.append(tree)
    d["definitions"] = {}
    d["definitions"]["nexus"] = tree_list.as_string("nexus")
    d["definitions"]["newick"] = tree_list.as_string("newick")
    json.dump(d, out)

generate_test_data_trees(sys.stdout)

