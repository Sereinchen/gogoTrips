<script setup lang="ts">
import { onLaunch } from '@dcloudio/uni-app'
import { initializeAuth } from '@/store/auth'

onLaunch(() => {
  console.log('GoGo Trip uni-app started')
  void initializeAuth()
})
</script>

<style>
@import './styles/tokens.css';

page {
  min-height: 100%;
  background: #f4f8f5;
  color: #17332d;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  box-sizing: border-box;
}

view, text, button, input, textarea { box-sizing: border-box; }
button::after { border: 0; }
</style>
