function check_inbox(Pos::AbstractPoint, Center::AbstractPoint, halflen::Number)
    if Pos.x < Center.x - halflen || Pos.x > Center.x + halflen ||
        Pos.y < Center.y - halflen || Pos.y > Center.y + halflen ||
        Pos.z < Center.z - halflen || Pos.z > Center.z + halflen
        return false
    end
    return true
end

function check_inradius(Pos::AbstractPoint, Center::AbstractPoint, radius::Number)
    dp = Pos - Center
    if dp * dp > radius * radius
        return false
    else
        return true
    end
end

function search_inbox_local(center::AbstractPoint, halflen::Number, tree::Octree;
                      startnode::Int64 = tree.MaxData + 1)
    MaxData = tree.MaxData

    no = startnode

    ExportFlag = Dict{Int64, Bool}()
    for p in tree.pids
        ExportFlag[p] = false
    end

    while no > 0
        if no <= MaxData
            p = no
            no = tree.NextNodes[no]

            if check_inbox(p.Pos, center, halflen)

            end
        else
            if no > MaxData + MaxTreenode
                # Tree force computation needs data in other processors
                # We send the particle data to there and receive the force result later

                target_task = tree.DomainTask[no - MaxData - MaxTreenode]
                ExportFlag[target_task] = true

                no = tree.NextNodes[no - MaxTreenode]
                continue
            end

            
        end
    end
end

function search_inradius_local(center::AbstractPoint, radius::Number, tree::Octree;
                         startnode::Int64 = tree.MaxData + 1)
    MaxData = tree.MaxData

    no = startnode

    ExportFlag = Dict{Int64, Bool}()
    for p in tree.pids
        ExportFlag[p] = false
    end

    while no > 0
        if no <= MaxData
            p = no
            no = tree.NextNodes[no]

            if check_inradius(p.Pos, center, radius)

            end
        else
            if no > MaxData + MaxTreenode
                # Tree force computation needs data in other processors
                # We send the particle data to there and receive the force result later

                target_task = tree.DomainTask[no - MaxData - MaxTreenode]
                ExportFlag[target_task] = true

                no = tree.NextNodes[no - MaxTreenode]
                continue
            end

            
        end
    end
end

