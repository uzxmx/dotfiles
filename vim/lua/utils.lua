local M = {}

M.retry = function(check_fn, success_cb, timeout_cb, defer, max_times)
  local counter = 0
  local check
  check = function()
    counter = counter + 1
    if vim.fn[check_fn]() == 1 then
      vim.fn[success_cb]()
    else
      if counter > max_times then
        vim.fn[timeout_cb]()
      else
        vim.defer_fn(check, defer)
      end
    end
  end
  vim.defer_fn(check, defer)
end

return M
