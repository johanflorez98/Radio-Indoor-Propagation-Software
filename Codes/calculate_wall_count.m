function wallCount = calculate_wall_count(image, start, goal)
        % Verify that init points are beetwen images's limits
        if any(start < 1) || any(start > size(image)) || any(goal < 1) || any(goal > size(image))
            error('Range is not support');
        end

        % Generate coordinates list middles between init points and goals
        x = linspace(start(1), goal(1), max(abs(goal(1) - start(1)), abs(goal(2) - start(2))) + 1);
        y = linspace(start(2), goal(2), max(abs(goal(1) - start(1)), abs(goal(2) - start(2))) + 1);
        
        x = round(x);
        y = round(y);
       
        % Calculate amount walls in the way, forgetting the walls with two
        % zeros followed
        wallCount = 0;
        prevPixelIsWall = false;
        
        for i = 1:numel(x)
            currentPixelIsWall = (image(y(i), x(i)) == 0);
            
            if ~currentPixelIsWall || ~prevPixelIsWall
                if currentPixelIsWall
                    if is_thick_wall(image, x(i), y(i))
                        continue; 
                    end
                end
                
                wallCount = wallCount + currentPixelIsWall;
            end
            
            prevPixelIsWall = currentPixelIsWall;
        end
    end