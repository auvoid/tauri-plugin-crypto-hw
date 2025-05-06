<script>
  // import Greet from './lib/Greet.svelte'
  import { generate, exists, getPublicKey } from 'tauri-plugin-crypto-api'
  import Sign from './lib/Sign.svelte';
  import Verify from './lib/Verify.svelte';


  let genRes = $state('')

	// test functions 
  async function _generate() {
    generate("default").then((returnValue) => {
      genRes = returnValue
    }).catch((error) => {
      genRes = error
    })
  }
  
  let existsRes = $state('')
  async function _exists() {
    exists("default").then((returnValue) => {
      existsRes = `${returnValue}`
    }).catch((error) => {
      existsRes = error
    })
  }


  let pubKey = $state('')
  async function _getPublicKey() {
    getPublicKey("default").then((returnValue) => {
      pubKey = returnValue
    }).catch((error) => {
      pubKey = error
    })
  }
</script>

<main class="container">

  <button onclick={_generate}>
    Generate Key Pair
  </button>
  <p>{genRes}</p>
  <button onclick={_exists}>
    Check Existence
  </button>
  <p>{existsRes}</p>
  <button onclick={_getPublicKey}>
    Get Public Key
  </button>
  <p class="long-text">{pubKey}</p>

  <!-- <h1>Welcome to Tauri!</h1>

  <div class="row">
    <a href="https://vite.dev" target="_blank">
      <img src="/vite.svg" class="logo vite" alt="Vite Logo" />
    </a>
    <a href="https://tauri.app" target="_blank">
      <img src="/tauri.svg" class="logo tauri" alt="Tauri Logo" />
    </a>
    <a href="https://svelte.dev" target="_blank">
      <img src="/svelte.svg" class="logo svelte" alt="Svelte Logo" />
    </a>
  </div>

  <p>
    Click on the Tauri, Vite, and Svelte logos to learn more.
  </p> -->

    <Sign />
    <Verify />

</main>

<style>
  .logo.vite:hover {
    filter: drop-shadow(0 0 2em #747bff);
  }

  .logo.svelte:hover {
    filter: drop-shadow(0 0 2em #ff3e00);
  }
</style>
