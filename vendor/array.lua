--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 11/25/15
-- Time: 20:34
-- To change this template use File | Settings | File Templates.
--

local _M = {};

function _M.split(str,delim)
    local list = {};
    local pos = 1;

    if string.find(str, delim) == nil then
        return {str};
    end

    if '' == delim then
        return {str};
    end

    local data = '';

    while true do
        local first, last = string.find(str, delim, pos);

        if first then
            data = string.sub(str, pos, first-1);

            table.insert(list, data);
            pos = last+1;
        else
            data = string.sub(str, pos);

            table.insert(list, data);
            break;
        end
    end

    return list;
end

-- search table by value return key
function _M.array_search(array, value)
    if not value or next(array) == nil then
        return nil;
    end

    for key, val in pairs(array) do
        if val == value then
            return key;
        end
    end

    return nil;
end

-- check value is in array, return bool, true - in  false - not in
function _M.in_array(array, value)
    if not value or next(array) == nil then
        return false;
    end

    for _, val in pairs(array) do
        if val == value then
            return true;
        end
    end

    return false;
end

-- 根据 key 获取 table 值
_M.array_get = function (array, key, default)
    if not array or next(array) == nil then
        return default;
    end

    return array[key] or default;
end

function _M.keys(source)
    if next(source) == nil then
        return {};
    end

    local keys = {};

    for key ,_ in pairs(source) do
        table.insert(keys, key);
    end

    return keys;
end

-- 数组交集
-- 返回在 array1 中 且 在 array2 中的值
function _M.intersect(array1, array2)
    if next(array1) == nil or next(array2) == nil then
        return {};
    end

    local result = {};
    for _, value in pairs(array1) do
        if (_M.in_array(array2, value)) then
            table.insert(result, value);
        end
    end

    return result;
end

-- 数组差集
-- 返回在 array1 中, 但不在 array2 中的值
function _M.diff(array1, array2)
    if next(array1) == nil then
        return {};
    end

    local result = {};
    for _, value in pairs(array1) do
        if (not _M.in_array(array2, value)) then
            table.insert(result, value);
        end
    end

    return result;
end

return _M;