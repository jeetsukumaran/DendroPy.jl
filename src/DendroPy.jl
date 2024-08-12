module DendroPy

export dendropy

import PyCall

const dendropy = PyCall.PyNULL()

function __init__()
    copy!(dendropy, PyCall.pyimport("dendropy"))
end

end
