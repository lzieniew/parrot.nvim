local logger = require("parrot.logger")

local Perplexity = {}
Perplexity.__index = Perplexity

local available_model_set = {
  ["sonar-small-chat"] = true,
  ["sonar-small-online"] = true,
  ["sonar-medium-chat"] = true,
  ["sonar-medium-online"] = true,
  ["llama-3-8b-instruct"] = true,
  ["llama-3-70b-instruct"] = true,
  ["codellama-70b-instruct"] = true,
  ["mistral-7b-instruct"] = true,
  ["mixtral-8x7b-instruct"] = true,
  ["mixtral-8x22b-instruct"] = true,
}

function Perplexity:new(endpoint, api_key)
  return setmetatable({
    endpoint = endpoint,
    api_key = api_key,
    name = "pplx",
  }, self)
end

function Perplexity:curl_params()
  return {
    self.endpoint,
    "-H",
    "authorization: Bearer " .. self.api_key,
    "content-type: text/event-stream",
  }
end

function Perplexity:verify()
  if type(self.api_key) == "table" then
    logger.error("api_key is still an unresolved command: " .. vim.inspect(self.api_key))
    return false
  elseif self.api_key and string.match(self.api_key, "%S") then
    return true
  else
    logger.error("Error with api key " .. self.name .. " " .. vim.inspect(self.api_key) .. " run :checkhealth parrot")
    return false
  end
end

function Perplexity:preprocess_messages(messages)
  return messages
end

function Perplexity:add_system_prompt(messages, sys_prompt)
  if sys_prompt ~= "" then
    table.insert(messages, { role = "system", content = sys_prompt })
  end
  return messages
end

function Perplexity:process(line)
  if line:match("chat%.completion%.chunk") or line:match("chat%.completion") then
    line = vim.json.decode(line)
    return line.choices[1].delta.content
  end
end

function Perplexity:check(agent)
  local model = type(agent.model) == "string" and agent.model or agent.model.model
  return available_model_set[model]
end

return Perplexity
