function mat = readJSONfile(JSONname)
    % read JSON file and construct a mat structure
    if exist(JSONname,'file')
        fid = fopen(JSONname);
        J = fileread(JSONname);
        fclose(fid);
        mat = loadjson(J);
    else
        error(['ERROR: cannot find file ',JSONname]);
    end
end