<script>
    import { signPayload } from "tauri-plugin-crypto-api";
  
    let payload = $state("")
    let signature = $state("")

    async function sign() {
      signature = await signPayload("default", payload);
    }
  </script>
  
  <div>
    <div class="row">
      <input id="greet-input" placeholder="Enter a message..." bind:value={payload} />
      <button onclick={sign}>
        Sign
      </button>
    </div>
    <p class="long-text">{signature}</p>
</div>
  
  