function P = get_permutation_matrix(perm)
    % determines matrix P such as when using the desired indexes from perm
    % the arrangement P*perm will be [1;2;...;n]; 
    %
    % Used in System.findEqPoint()

    N = length(perm);
    P = zeros(N);
    
    for k = 1:N
        P(perm(k),k) = 1;
    end
    
    P = P';
    
end