import Foundation
import Supabase

/// Lovable Cloud (Supabase) project shared with the website. These are the same public
/// values as the website's .env; the publishable key is safe to ship because every
/// table is protected by row-level security.
enum SupabaseConfig {
  static let url = URL(string: "https://nbxbqdypmuznhuotxuee.supabase.co")!
  static let publishableKey = "sb_publishable_doc9x4J_slLvrNvQFwNXdw__XKnhl8Y"
}

let supabase = SupabaseClient(
  supabaseURL: SupabaseConfig.url,
  supabaseKey: SupabaseConfig.publishableKey
)
