<script>
    import { verifySignature } from "tauri-plugin-crypto-api";

    let payload = $state("");
    let signature = $state("");

    let result = $state(false);

    async function verify() {
        result = await verifySignature("default", payload, signature);
        console.log("Result: ", result)
    }
</script>

<div>
    <div class="row">
        <div class="column">
            <input id="greet-input" placeholder="Enter a message..." bind:value={payload} />
            <input id="greet-input" placeholder="Enter a signature..." bind:value={signature} />
        </div>
        <button onclick={verify}>
            Verify
        </button>
    </div>
    <p>{result}</p>
</div>