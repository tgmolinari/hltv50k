-- Everyone's favorite Torch imports
require 'nn';
require 'optim';
require 'cutorch';
local sys = require 'sys';
Dataset = require 'dataset.Dataset';
torch.setdefaulttensortype('torch.FloatTensor');
-- Data prep
local csds = Dataset("/media/tom/shared/full_train.csv")

function trainModel(model, epochs)
    --local params, grad_params = model:getParameters()
    local criterion = nn.BCECriterion()
    local optimState = {learningRate = .03}
    local e = 1
    while e <= epochs do
      local getBatch, numBatches = csds.sampledBatcher({
            batchSize = 8,
            inputDims = {3,200,200},
            samplerKind = 'permutation',
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
      print("Total batches: " .. numBatches())
      local params, gradParams = model:getParameters()
      model:training()
      while b <= numBatches() do
          collectgarbage()
          print("BATCH #" .. b)
          local batch = getBatch()
          function feval(params)
            gradParams:zero()	
            local preds = model:forward(batch['input'])
          	local labels = batch['target']-1
          	local loss = criterion:forward(preds,labels)
          	local gradOutputs = criterion:backward(preds,labels)
          	model:backward(batch['input'], gradOutputs)
            return loss, gradParams
          end
          optim.rmsprop(feval,params,optimState)
          b = b + 1
      end
      e = e + 1
      print("END OF EPOCH")
    end
end


-- Model prep
local cs_learn = nn.Sequential()
cs_learn:add(nn.SpatialConvolution(3,16,12,12,2,2))
cs_learn:add(nn.SpatialBatchNormalization(16, 1e-3))
cs_learn:add(nn.SpatialMaxPooling(2,2))
cs_learn:add(nn.ReLU())
cs_learn:add(nn.SpatialConvolution(16,32,6,6,2,2))
cs_learn:add(nn.SpatialBatchNormalization(32, 1e-3))
cs_learn:add(nn.SpatialMaxPooling(2,2))
cs_learn:add(nn.ReLU())
cs_learn:add(nn.SpatialConvolution(32,64,3,3))
cs_learn:add(nn.SpatialBatchNormalization(64, 1e-3))
cs_learn:add(nn.SpatialMaxPooling(2,2))
cs_learn:add(nn.ReLU())
cs_learn:add(nn.View(64*4*4))--Careful with vectorizing your inputs, as if you specify incorrectly the model won't care and it'll eat your lunch (it's the reason we only got 1 prediction when we based in a batch.)
cs_learn:add(nn.Linear(64*4*4,1))
cs_learn:add(nn.Sigmoid())
--torch.save('cs_learn_model.t7', cs_learn)
-- Training
local t0 = sys.clock()
trainModel(cs_learn,3)
local dt = (sys.clock()-t0)
torch.save('cs_learn_model_7_sig.t7', cs_learn)
print("Total seconds to train " .. numBatches() .." batches of ~8 images)")
print(dt)
