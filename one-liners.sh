#!/bin/bash

terraform show -json | jq '[
(.values.root_module.resources[] | 
    select(.mode == "managed") | 
    { address: .address, id: .values.id }),
(.values.root_module.child_modules[].resources[] |
    select(.mode == "managed") | 
    { address: .address, id: .values.id })
]'
