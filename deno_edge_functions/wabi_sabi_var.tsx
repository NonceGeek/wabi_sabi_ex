import { Application, Router } from "https://deno.land/x/oak/mod.ts";
import { oakCors } from "https://deno.land/x/cors/mod.ts";

console.log("Hello from Wabi Sabi Var!");

const router = new Router();

router.get("/", async (context) => {
  const randomValue = Math.random();
  const responseBody = randomValue < 0.5 ? "🏀" : "💩";
  context.response.body = responseBody;
});

const app = new Application();
app.use(oakCors()); // Enable CORS for All Routes
app.use(router.routes());

console.info("CORS-enabled web server listening on port 8000");

await app.listen({ port: 8000 });
