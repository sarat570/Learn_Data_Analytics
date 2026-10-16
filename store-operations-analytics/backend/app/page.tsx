import {getChatGPTUser,chatGPTSignInPath,chatGPTSignOutPath} from './chatgpt-auth';
import {database} from '../lib/server';
import Workspace from './workspace';
export const dynamic='force-dynamic';
export default async function Home(){const user=await getChatGPTUser();if(!user)return <main className="login"><div className="login-card"><span className="eyebrow">STOREOPS / SECURE WORKSPACE</span><h1>Your stores.<br/>One trusted workspace.</h1><p>Sign in to manage store access, upload daily POS records, and review sales and workforce plans.</p><a className="button" href={chatGPTSignInPath('/')} target="_top">Sign in with ChatGPT →</a><small>No shared passwords. Store permissions are checked on the server.</small></div></main>;const count=await database().prepare('SELECT COUNT(*) n FROM memberships').first<{n:number}>();return <Workspace initialSetup={count?.n===0} email={user.email} signOut={chatGPTSignOutPath('/')}/>;}
