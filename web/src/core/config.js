/**
 * 网站配置文件
 */
import packageInfo from '../../package.json'

const greenText = (text) => `\x1b[32m${text}\x1b[0m`

export const config = {
  appName: 'Gin-Vue-Admin',
  appLogo: 'logo.png',
  showViteLogo: true,
  KeepAliveTabs: true,
  logs: []
}

export const viteLogo = (env) => {
  if (config.showViteLogo) {
    console.log(
      greenText(
        `> 欢迎使用=哈雷彗星后台管理系统`
      )
    )
  }
}

export default config
