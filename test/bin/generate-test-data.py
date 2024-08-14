#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import dendropy
import random
import json

def add_tree_features_(tree):
    tree = add_internal_labels_(tree)
    return tree

def add_internal_labels_(tree):
    ind_index = 1
    for nd in tree:
        if nd._child_nodes:
            nd.label = f"I{ind_index:03d}"
            ind_index += 1
    return tree

def export_tree_features(out, d):
    pass

def extract_tree_features(tree):
    d = {}
    for feature_class in (
        ( "edge_lengths", lambda nd: nd.edge.length if nd.edge.length else 0.0, ),
        ( "labels", lambda nd: nd.taxon.label if nd.taxon else nd.label, ),
        ( "node_ages", lambda nd: nd.age, ),
    ):
        d[feature_class] = {}
    return d

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
        tree = add_tree_features_(tree)
        features = extract_tree_features(tree)
        export_tree_features(out, features)

generate_test_data_trees(sys.stdout)

