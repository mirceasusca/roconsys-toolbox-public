function od = add_dict_fields(nd,od)
% Append fields of nd - new_dict to od - old_dict
% DEPRECATED

nd_keys = nd.keys();
n = length(nd_keys);

od_keys = od.keys();

for i=1:n
    if ~is_in_list(nd_keys{i}, od_keys)
        error('Warning, field not found in dict.');
    end
    od{nd_keys{i}} = nd{nd_keys{i}};
end

end