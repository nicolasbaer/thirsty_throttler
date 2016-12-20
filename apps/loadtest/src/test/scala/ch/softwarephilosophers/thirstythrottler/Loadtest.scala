package ch.softwarephilosophers.thirstythrottler

import io.gatling.core.Predef._
import io.gatling.core.feeder.RecordSeqFeederBuilder
import io.gatling.http.Predef._
import io.gatling.http.response.ResponseWrapper

import scala.concurrent.duration._
import scala.util.Random


class StressTest extends Simulation {

  val httpConf = http
    .baseURL("http://localhost:8080")
    
  setUp(
    scenario("most-important")
      .exec(http("cart").get("/cart").check(header("sessionid").saveAs("sessionid")))
      .exec(http("cart").get("/cart").header("sessionid", "${sessionid}"))
      .exec(http("cart").get("/cart").header("sessionid", "${sessionid}"))
      .exec(http("cart").get("/cart").header("sessionid", "${sessionid}"))
      .exec(http("cart").get("/cart").header("sessionid", "${sessionid}"))
      .inject(constantUsersPerSec(5) during(5 minutes)).protocols(httpConf),
    scenario("less-important")
      .exec(http("home").get("/home").check(header("sessionid").saveAs("sessionid")))
      .exec(http("home").get("/home").header("sessionid", "${sessionid}"))
      .exec(http("home").get("/home").header("sessionid", "${sessionid}"))
      .inject(constantUsersPerSec(5) during(5 minutes)).protocols(httpConf),
    scenario("senseless")
      .exec(http("foo").get("/foo"))
      .inject(constantUsersPerSec(5) during(5 minutes)).protocols(httpConf)
  )
}


class StressTestRemote extends Simulation {

  val httpConf = http
    .baseURL("http://192.168.2.244:8080")
    
  setUp(
    scenario("most-important")
      .exec(http("cart").get("/cart"))
      .inject(constantUsersPerSec(100) during(1 minutes)).protocols(httpConf),
    scenario("less-important")
      .exec(http("home").get("/home"))
      .inject(constantUsersPerSec(100) during(1 minutes)).protocols(httpConf),
    scenario("senseless")
      .exec(http("foo").get("/foo"))
      .inject(constantUsersPerSec(100) during(1 minutes)).protocols(httpConf)
  )
}