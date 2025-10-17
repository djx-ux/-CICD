<template>
  <div>
    <router-view v-slot="{ Component }">
      <transition mode="out-in" name="el-fade-in-linear">
        <keep-alive :include="routerStore.keepAliveRouters">
          <component :is="Component" />
        </keep-alive>
      </transition>
    </router-view>
  </div>
  
</template>

<script setup>
defineOptions({
  // 路由容器名称用于 Keep-Alive
  name: 'AnchorModule'
})
import { useRouterStore } from '@/pinia/modules/router'
const routerStore = useRouterStore()
</script>

<style scoped>
</style>






