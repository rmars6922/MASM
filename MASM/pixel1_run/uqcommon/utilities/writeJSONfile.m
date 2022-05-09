function writeJSONfile(mat, JSONname)
    % write a mat structure to a JSON file
    try
        fid = fopen(JSONname,'w');
        fprintf(fid,'%s',savejson('',mat));
        fclose(fid);
    catch
        error(['ERROR: cannot write to file ',JSONname]);
    end
end