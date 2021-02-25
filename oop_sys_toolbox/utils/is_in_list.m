function found = is_in_list(item,list)

n = length(list);

found = false;
for i=1:n
    if item == list{i}
        found = true;
        break
    end
end

end