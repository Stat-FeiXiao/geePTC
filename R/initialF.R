#' Title initial cumulative baseline hazard function.
#'
#' @param Time right censored data which is the follow up time.
#' @param Status the censoring indicator, 1 = event of interest happens, and 0 = censoring.
#' @param X a matrix of covariates that that may have effect on the failure times.
#' @param id a vector which identifies the clusters. The length of \code{id} should be the same as the number of observations.
#'
#' @return initial cumulative baseline hazard function.
#' @export

initialF <- function(Time, Status, X,  id,  betaest) {
  w <- Status
  t2 <- Time
  K <- length(unique(id))
  n <- as.vector(table(id))
  Kn <- sum(n)
  X<-as.matrix(X[,-1])
  cens <- Status
  t11 <- sort(Time)
  c11 <- Status[order(Time)]
  x111 <- as.matrix(X[order(Time), ])
  tt1 <- unique(t11[c11 == 1])
  g11<-rep(1,Kn)
  kk <- length(table(t11[c11 == 1]))
  dd <- as.matrix(table(t11[c11 == 1]))
  betaest <- coxph(Surv(Time, Status) ~ X)$coef 
  gSSS1 <- rep(0, kk)
  gSS <- rep(0, kk)
  gSS1 <- rep(1, kk)
  gSS[1] <- dd[1]/(sum(g11[min((1:(Kn))[t11 == tt1[1]]):(Kn)] * exp(as.matrix(x111[min((1:(Kn))[t11 == tt1[1]]):(Kn), ])%*%betaest  )))
  for (i in 1:(kk - 1)) {
    gSS[i + 1] <- gSS[i] + dd[i + 1]/(sum(g11[min((1:(Kn))[t11 == tt1[i + 1]]):(Kn)] * exp(as.matrix(x111[min((1:(Kn))[t11 == tt1[1+i]]):(Kn), ])%*%betaest  )))
  }
  gSS1 <- exp(-gSS)
  gSS <-gSS/max(gSS)
  gss=seq(1,kk)/kk
  gs <- rep(0, Kn)
  gSS3 <- rep(0, Kn)
  for (i in 1:(Kn)) {
    kk1 <- 1

    if (t2[i] < tt1[1]) {
      gs[i]<- 1e-08
      gSS3[i] <- 1e-08
    } else {
      if (t2[i] >= tt1[kk]) {
        gs[i]<- 1
        gSS3[i] <- 1
      } else {
        repeat {
          if(t2[i]>=tt1[kk1]) kk1=kk1+1
          else break
        }
        {
          gs[i] <- gss[kk1 - 1]
          gSS3[i] <- gSS[kk1 - 1]
        }
      }
    }
  }
  list(Lambda = gSS3,gs=gs)
}
