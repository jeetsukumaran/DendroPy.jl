#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import dendropy
import random
import json

def add_tree_features_(tree, tree_idx):
    tree.key = f"Tree{tree_idx:03d}"
    tree = add_node_data(tree, tree.key)
    return tree

def add_node_data(tree, tree_key):
    ind_index = 1
    for nd_idx, nd in enumerate(tree):
        nd.key = ".".join([tree_key, f"Node{nd_idx+1}"])
        if nd._child_nodes:
            nd.label = f"I{ind_index:03d}"
            ind_index += 1
    return tree

def extract_tree_features(tree):
    d = {}
    for feature_class in (
        ( "keys", lambda nd: nd.key, ),
        ( "edge_lengths", lambda nd: nd.edge.length if nd.edge.length else 0.0, ),
        ( "labels", lambda nd: nd.taxon.label if nd.taxon else nd.label, ),
        ( "node_ages", lambda nd: nd.age, ),
    ):
        feature_key = feature_class[0]
        feature_fn = feature_class[1]
        d[feature_key] = {}
        d[feature_key]["postorder"] = [feature_fn(nd) for nd in tree.postorder_node_iter()]
        d[feature_key]["preorder"] = [feature_fn(nd) for nd in tree.preorder_node_iter()]
        d[feature_key]["leaves"] = [feature_fn(nd) for nd in tree.leaf_nodes()]
        d[feature_key]["internal"] = [feature_fn(nd) for nd in tree.internal_nodes()]
    return d

def export_tree_features(out, d):
    print(d)
    # json.dump(d, out)

def generate_test_data_trees(
    out,
    random_seed=None,
):
    rng = random.Random(random_seed)
    tree_idx = 1
    for leaf_set_size in range(2, 24):
        leaf_labels = [f"T{idx:03d}" for idx in range(leaf_set_size)]
        tns = dendropy.TaxonNamespace(leaf_labels)
        tree = dendropy.simulate.pure_kingman_tree(tns)
        tree = add_tree_features_(tree, tree_idx)
        features = extract_tree_features(tree)
        export_tree_features(out, features)
        tree_idx += 1

generate_test_data_trees(sys.stdout)

