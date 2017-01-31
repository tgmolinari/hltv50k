-- Everyone's favorite Torch imports
require 'nn';
require 'optim';
require 'cutorch';
Dataset = require 'dataset.Dataset';
torch.setdefaulttensortype('torch.FloatTensor');
-- Data prep
local csds = Dataset("/media/tom/shared/full_test.csv")

function trainModel(model)
    --local params, grad_params = model:getParameters()
    local criterion = nn.BCECriterion()
    local getBatch, numBatches = csds.sampledBatcher({
          batchSize = 8,
          inputDims = {3,200,200},
          samplerKind = 'linear',
          verbose = true,
          processor = function(res, processorOpt, input)
                  --return function(res, processorOpt, input)
                  -- This code is from the torch-dataset repo on git, curtosy the Twitter team
                  -- However, I attempted to turn the function into a closure (I'm led to believe it'll run faster)
                  -- Turn the res string into a ByteTensor (containing the PNG file's contents)
                  local image = require 'image';
                  local bytes = torch.ByteTensor(#res)
                  bytes:storage():string(res)
                  -- Decompress the PNG bytes into a Tensor
                  local pixels = image.decompressPNG(bytes)
                  -- Copy the pixels tensor into the mini-batch
                  input:copy(pixels)
                  return true
                 --end
          end,
       })
    
    
    local b = 1
    local acc = 0
    print("Total batches: " .. numBatches())
    model:evaluate()
    local results = {}
    while b <= numBatches() do
        collectgarbage()
        print("BATCH #" .. b)
        local batch = getBatch()
        for s = 1, batch['index']:size(1) do
            local pred = model:forward(batch['input'][s])
            local label = torch.FloatTensor({batch['target'][s]-1})
            if math.floor(pred[1]+.05) == label[1] then acc = acc + 1 end
            results[b] = pred[1] .. "," .. label[1]
        end
        b = b + 1
    end
    print("TOTAL PREDS: " .. b)
    print("TOTAL RIGHT: " .. acc)
    torch.save("res_tab_balcla.t7", results)
end

local cs_learn = torch.load('cs_learn_model_4.t7')
trainModel(cs_learn)
