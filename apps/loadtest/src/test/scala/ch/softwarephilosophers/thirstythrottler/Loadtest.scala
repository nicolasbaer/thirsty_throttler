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
    scenario("most-important").exec(http("cart").get("/cart")).inject(constantUsersPerSec(20) during(5 minutes)).protocols(httpConf),
    scenario("less-important").exec(http("home").get("/home")).inject(constantUsersPerSec(20) during(5 minutes)).protocols(httpConf),
    scenario("senseless").exec(http("foo").get("/foo")).inject(constantUsersPerSec(20) during(5 minutes)).protocols(httpConf)
  )
}