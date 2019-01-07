binfile1 = "MODISA/A20140012014365.L3b_YR_CHL.main"
binfile2 = "VIIRSN/V20140012014365.L3b_YR_NPP_CHL.nc"

chl1 = readl3bin(binfile1,'chlor_a',lon1,lat1,bins1)
chl2 = readl3bin_nc(binfile2,'chl_ocx',lon2,lat2,bins2)

nbin = bin_mtch(bins1,bins2,s1,s2)

chl1 = chl1[s1]
chl2 = chl2[s2]



end
