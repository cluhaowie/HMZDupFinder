##------------------------------------------------------------------------------
##' Calculate Z-TPM with nearest references and write bed file for visualizetion
##'
##'
##' @param perMat cor matrix of samples
##' @param tpmDtOrdered	 object returned by reorderBedAndRpkmDt
##' @param mc.cores number of core used for parallel running
##' @param bedOrdered an object from prepareBed function
##' @param outputDir	  a character value of output directory
##' @export
##------------------------------------------------------------------------------

CalcuZtpm <- function(perMat,tpmDtOrdered,bedOrdered,outputDir,mc.cores = 4){
    perMat <- as.data.table(perMat)
    print("[******Calculate Z-TPM**********]")
    candidateExon <- pbmclapply(perMat,.calZscore,tpmDtOrdered,mc.cores=mc.cores)
    print("[******Calculate Ratio**********]")
    candidateExon2 <- pbmclapply(perMat,.calRatio,tpmDtOrdered,mc.cores=mc.cores)
    print("[******Binding the values**********]")
    #candidateZscore<-bind_cols(candidateExon)
    #candidateRatio<-bind_cols(candidateExon2)
    print("[******Write z-tpm and ratio to individual file**********]")
    bedOrdered <- as.data.table(bedOrdered)
    lapply(names(candidateExon),function(x){
        outputFile <- paste0(outputDir,"/",x,".ztpm.ratio.bed")
        print(paste0("Writring ", outputFile ))
        out <- data.table(bedOrdered[,c(1:3)],
                          ztpm=as.numeric(unlist(candidateExon[x])),
                          ratio=as.numeric(unlist(candidateExon2[x])))
        write.table(out,file=outputFile, sep="\t", col.names=T, row.names=F, quote=F)
    })
}

