function isThick = isThickWall(image, x, y)
        % Verify if the pixel (x, y) is part of a wall with width two
        % pixels
        [rows, cols] = size(image);
        
        if y > 1 && y < rows && x > 1 && x < cols
            neighbors = [image(y-1, x), image(y+1, x), image(y, x-1), image(y, x+1)];
            isThick = all(neighbors == 0);
        else
            isThick = false;
        end
    end