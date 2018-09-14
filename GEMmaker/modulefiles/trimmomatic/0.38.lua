-- -*- lua -*-
whatis("A flexible read trimming tool for Illumina NGS data")

prepend_path("PATH", "/usr/local/Trimmomatic-0.38/")
prepend_path("CLASSPATH", "/usr/local/Trimmomatic-0.38/trimmomatic-0.38.jar")
prepend_path("ILLUMINACLIP_PATH", "/usr/local/Trimmomatic-0.38/adapters")


--[[
Build:
    # unzip, that's all
--]]

